import { User } from "src/model/user.entity";
import { Column, CreateDateColumn, Entity, ManyToOne, OneToMany, PrimaryColumn, UpdateDateColumn } from "typeorm";
import { SavingGold } from "./saving-gold.entity";

@Entity()
export class SavingGoldOwner {
    @PrimaryColumn({ generated: "uuid" })
    id: string

    @Column({length:100})
    name_own: string
        
    @ManyToOne(() => User, (user)=> user.savingGoldOwner)
    user: User;
    
    @OneToMany(() => SavingGold, (savGold) => savGold.owner_gold, { nullable:false})
    savingGold: SavingGold[]
    
    @CreateDateColumn()
    createdon: Date;
        
    @UpdateDateColumn()
    updatedon: Date;
}
